# DynamoDB – table & seed

**Region:** us-west-1  
**Table:** Employees (PK: `id` as String)  
**Billing mode:** On-demand (PAY_PER_REQUEST)

## Files
- `dynamo-create.sh` – Create the `Employees` table.
- `dynamo-seed.sh` – Seed a couple of sample rows (E1001/E1002).
- `dynamo-scan.sh` – Quick scan to verify data.
- `dynamo-delete-table.sh` – (optional) Delete the table.
- `seed.json` – Sample items used by `dynamo-seed.sh`.

## Quick start
```bash
cd dynamodb
chmod +x dynamo-*.sh

# 1) Create table
./dynamo-create.sh

# 2) Seed data
./dynamo-seed.sh

# 3) Verify
./dynamo-scan.sh
```

## Table schema
- Partition key: `id` (String)
- Attributes (sample app):
  - `name` (String)
  - `salary` (Number)
  - `dateOfJoin` (String, ISO date)

> Notes:
> - Scripts use **on-demand capacity** to avoid throughput settings.
> - If a table with the same name exists, creation will be skipped.
> - Adjust `REGION` or `TABLE` at the top of each script if needed.
