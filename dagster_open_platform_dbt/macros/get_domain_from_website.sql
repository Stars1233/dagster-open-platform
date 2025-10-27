{% macro get_domain_from_website(website) -%}
    --    Retrieves the full domain including subdomains from a website URL
    --    Examples:
    --      https://compass.dagster.io/path -> compass.dagster.io
    --      https://www.dagster.io -> dagster.io
    --      https://dagster.io -> dagster.io
    --      https://docs.dagster.io/some/path -> docs.dagster.io
    --
    --    Strategy:
    --      1. Strip protocol (http:// or https://)
    --      2. Strip www. if present
    --      3. Extract domain (everything before first / or ?)
    regexp_replace(
        split_part(
            regexp_replace(
                regexp_replace({{website}}, $$^https?://$$, '', 1, 1, 'i'),
                $$^www\.$$, '', 1, 1, 'i'
            ),
            '/', 1
        ),
        '\\?.*$', '', 1, 1
    )
{%- endmacro %}