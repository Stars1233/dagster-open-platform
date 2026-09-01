{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}
    {%- if target.name in ('prod', 'branch_deployment', 'dogfood', 'sdf', 'dev', 'purina_ci') and custom_database_name is none -%}
        {% if node.fqn|length <= 2 %}
            {{ default_database }}
        {% elif target.name == 'branch_deployment' %}
            {% set prefix = node.fqn[1] %}
            {# Defaulted like profiles.yml: set whenever a branch deployment
               actually runs, but not during the `dbt parse` at deploy time. #}
            {{ return([prefix | trim, 'clone', env_var('DAGSTER_CLOUD_PULL_REQUEST_ID', '')]|join('_')) }}
        {% elif target.name == 'purina_ci' %}
            {% set prefix = node.fqn[1] %}
            {{ return([prefix | trim, 'ci']|join('_')) }}
        {% else %}
            {% set prefix = node.fqn[1] %}
            {{ prefix | trim }}
        {% endif %}
    {%- else -%}
        {{ default_database }}
    {%- endif -%}

{%- endmacro %}