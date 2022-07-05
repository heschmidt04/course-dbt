{# monitors changes in price and/or inventory #}

{% snapshot products_snapshot %}

  {{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='check',
      check_cols=['price', 'inventory']
    )
  }}

SELECT 
    * 
FROM 
    {{ source( 'src_greenery', 'products') }}

{% endsnapshot %}