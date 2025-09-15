import json, os, boto3
ddb = boto3.client("dynamodb")
TABLE = os.environ.get("TABLE_NAME", "Employees")

CORS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization,Content-Type",
    "Access-Control-Allow-Methods": "GET,OPTIONS",
}
def resp(code, body): return {"statusCode": code, "headers": CORS, "body": json.dumps(body)}

def lambda_handler(event, _):
    # Read id from /hr/{id}; fallback to ?id=...
    emp_id = (
        (event.get("pathParameters") or {}).get("id")
        or (event.get("queryStringParameters") or {}).get("id")
        or ""
    ).strip()
    if not emp_id:
        return resp(400, {"message": "Missing id"})

    # Fetch from DynamoDB
    r = ddb.get_item(TableName=TABLE, Key={"id": {"S": emp_id}})
    item = r.get("Item")
    if not item:
        return resp(404, {"message": f"Employee {emp_id} not found"})

    out = {"id": emp_id}
    for k, v in item.items():
        if k == "id": continue
        if "S" in v: out[k] = v["S"]
        elif "N" in v: out[k] = float(v["N"]) if "." in v["N"] else int(v["N"])
        elif "BOOL" in v: out[k] = bool(v["BOOL"])
    return resp(200, out)
