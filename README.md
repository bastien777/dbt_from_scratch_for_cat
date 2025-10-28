# dbt Databricks Project - Setup and Getting Started

## 📋 Description

This project uses dbt (data build tool) to transform and model data in Databricks. dbt enables managing SQL transformations in a modular, testable, and documented way, leveraging Databricks' powerful lakehouse architecture.

## 🎯 Objectives

- Centralize data transformations in Databricks
- Ensure data quality through automated testing
- Document models and data sources
- Facilitate collaboration between data analysts and engineers
- Leverage Delta Lake and Databricks features

## 🛠️ Prerequisites

Before starting, ensure you have:

- Python 3.8 or higher
- pip (Python package manager)
- Git
- Access to a Databricks workspace
- Databricks personal access token or OAuth credentials
- SQL Warehouse or All-Purpose Cluster in Databricks

## 📦 Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd <project-name>
```

### 2. Create a virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

## ⚙️ Configuration

### 1. Configure dbt profile

Create or modify the file `~/.dbt/profiles.yml`:

```yaml
databricks_project:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: dev_catalog  # Unity Catalog (optional)
      schema: dbt_dev
      host: your-workspace.cloud.databricks.com
      http_path: /sql/1.0/warehouses/your-warehouse-id
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      threads: 4
    
    prod:
      type: databricks
      catalog: prod_catalog
      schema: analytics
      host: your-workspace.cloud.databricks.com
      http_path: /sql/1.0/warehouses/your-prod-warehouse-id
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      threads: 8
```

**Alternative configuration using SQL Warehouse:**

```yaml
databricks_project:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: main  # Unity Catalog
      schema: dbt_dev
      host: your-workspace.cloud.databricks.com
      http_path: /sql/1.0/warehouses/abc123def456
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      threads: 4
```

### 2. Environment variables

Create a `.env` file at the project root:

```bash
DATABRICKS_TOKEN=dapi1234567890abcdef
DATABRICKS_HOST=your-workspace.cloud.databricks.com
DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/your-warehouse-id
```

**Important:** Add `.env` to your `.gitignore` to avoid versioning secrets.

### 3. Get your Databricks credentials

**Personal Access Token:**
1. Log into Databricks workspace
2. Click your username → Settings → Developer
3. Under Access tokens, click "Manage" → "Generate new token"
4. Copy and save the token securely

**SQL Warehouse HTTP Path:**
1. Go to SQL Warehouses in Databricks
2. Select your warehouse
3. Click "Connection details"
4. Copy the "Server hostname" and "HTTP path"

## 🏗️ Project Structure

```
.
├── analyses/          # Ad-hoc SQL queries
├── macros/            # Reusable SQL functions
├── models/            # Transformation models
│   ├── staging/       # Staging models (raw sources)
│   ├── intermediate/  # Intermediate models
│   └── marts/         # Final models (data marts)
├── seeds/             # CSV reference files
├── snapshots/         # SCD (Slowly Changing Dimensions) tables
├── tests/             # Custom tests
├── dbt_project.yml    # Project configuration
├── packages.yml       # External dbt packages
└── requirements.txt   # Python dependencies
```

## 🚀 Main Commands

### Verify configuration

```bash
dbt debug
```

### Install dbt packages

```bash
dbt deps
```

### Run models

```bash
# Run all models
dbt run

# Run a specific model
dbt run --select model_name

# Run models from a folder
dbt run --select staging.*

# Full refresh mode (complete rebuild)
dbt run --full-refresh

# Run with specific materialization
dbt run --select model_name --vars 'materialized: incremental'
```

### Test models

```bash
# Run all tests
dbt test

# Test a specific model
dbt test --select model_name

# Test sources
dbt test --select source:*
```

### Generate documentation

```bash
# Generate documentation
dbt docs generate

# Serve documentation locally
dbt docs serve
```

### Load seeds

```bash
dbt seed
```

### Compile models (without execution)

```bash
dbt compile
```

## 🎯 Databricks-Specific Features

### Unity Catalog

This project supports Unity Catalog for data governance:

```sql
-- Model example with Unity Catalog
{{ config(
    materialized='table',
    catalog='production',
    schema='analytics'
) }}

SELECT * FROM {{ source('raw', 'customers') }}
```

### Delta Lake Optimizations

Use Delta Lake features in your models:

```sql
{{ config(
    materialized='incremental',
    file_format='delta',
    incremental_strategy='merge',
    unique_key='id',
    on_schema_change='sync_all_columns'
) }}
```

### Liquid Clustering (Databricks 13.3+)

```sql
{{ config(
    materialized='table',
    file_format='delta',
    liquid_clustered_by='date, category'
) }}
```

## 🔄 Development Workflow

1. Create a branch for your changes
2. Develop models in the appropriate folder
3. Test locally with `dbt run` and `dbt test`
4. Document your models in `.yml` files
5. Create a pull request
6. After validation, merge to main branch
7. Deploy to production

## 📝 Best Practices

- Always test models before deployment
- Document each model and important columns
- Use explicit and consistent naming conventions
- Avoid SELECT * in production models
- Use incremental models for large tables
- Leverage Delta Lake optimizations (Z-ordering, liquid clustering)
- Use Unity Catalog for proper data governance
- Configure appropriate file formats (Delta recommended)
- Use macros to avoid code duplication
- Monitor query performance in Databricks

## 🧪 Testing

dbt tests include:

- **Generic tests**: `unique`, `not_null`, `accepted_values`, `relationships`
- **Custom tests**: defined in the `tests/` folder
- **Source tests**: validation of source data

Example test in a `schema.yml` file:

```yaml
models:
  - name: dim_customers
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      - name: email
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['active', 'inactive', 'pending']
```

## 🔐 Security Considerations

- Never commit tokens or credentials to Git
- Use environment variables for sensitive data
- Rotate access tokens regularly
- Use service principals for production deployments
- Implement proper Unity Catalog permissions
- Use secret scopes in Databricks when possible

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📚 Resources

- [dbt Official Documentation](https://docs.getdbt.com/)
- [dbt-databricks adapter documentation](https://docs.getdbt.com/reference/warehouse-setups/databricks-setup)
- [Databricks SQL Documentation](https://docs.databricks.com/sql/index.html)
- [Unity Catalog Documentation](https://docs.databricks.com/data-governance/unity-catalog/index.html)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [dbt Learn (free courses)](https://courses.getdbt.com/)

## 📧 Contact

For any questions, contact [your-email@example.com]

## 📄 License

This project is licensed under [MIT/Apache/etc.]