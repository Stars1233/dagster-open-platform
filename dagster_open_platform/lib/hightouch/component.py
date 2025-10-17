import os
from collections.abc import Mapping
from typing import Any

import dagster as dg
from dagster.components import Component, Model, Resolvable, ResolvedAssetSpec
from dagster_dbt import get_asset_key_for_model
from dagster_open_platform.definitions import global_freshness_policy
from dagster_open_platform.defs.hightouch.py.resources import ConfigurableHightouchResource


def dbt_asset_key(model_name: str) -> dg.AssetKey:
    from dagster_open_platform.defs.dbt.assets import get_dbt_non_partitioned_models

    return get_asset_key_for_model([get_dbt_non_partitioned_models()], model_name)


class DopHightouchSyncComponent(Component, Resolvable, Model):
    asset: ResolvedAssetSpec
    sync_id_env_var: str

    @classmethod
    def get_additional_scope(cls) -> Mapping[str, Any]:
        return {"dbt_asset_key": dbt_asset_key}

    def build_defs(self, context) -> dg.Definitions:
        @dg.multi_asset(
            name=self.asset.key.path[0],
            specs=[self.asset.replace_attributes(freshness_policy=global_freshness_policy)],
        )
        def _assets(hightouch: ConfigurableHightouchResource):
            result = hightouch.sync_and_poll(os.getenv(self.sync_id_env_var, ""))
            return dg.MaterializeResult(
                metadata={
                    "sync_details": result.sync_details,
                    "sync_run_details": result.sync_run_details,
                    "destination_details": result.destination_details,
                    "query_size": result.sync_run_details.get("querySize"),
                    "completion_ratio": result.sync_run_details.get("completionRatio"),
                    "failed_rows": result.sync_run_details.get("failedRows", {}).get("addedCount"),
                }
            )

        return dg.Definitions(assets=[_assets])
