
import json, os, boto3
ddb = boto3.client("dynamodb")
TABLE = os.environ.get("TABLE_NAME", "Employees")
CORS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization,Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
}

def resp(code, body): return {"statusCode": code, "headers": CORS, "body": json.dumps(body)}

def lambda_handler(event, _):
    if (event.get("httpMethod") or "").upper() == "OPTIONS":
        return resp(200, {"ok": True})

    # 仅管理员可写（可选）
    # claims = (event.get("requestContext") or {}).get("authorizer", {}).get("claims", {})
    # groups = (claims.get("cognito:groups") or "").split(",")
    # if "admins" not in [g.strip() for g in groups if g.strip()]:
    #     return resp(403, {"message":"Only admins can write"})

    try:
        body = json.loads(event.get("body") or "{}")
        id_ = body.get("id")
        name = body.get("name")
        salary = body.get("salary")
        dateOfJoin = body.get("dateOfJoin")
        if not all([id_, name, salary, dateOfJoin]):
            return resp(400, {"message":"id, name, salary, dateOfJoin are required"})

        ddb.put_item(
            TableName=TABLE,
            Item={
                "id":{"S":str(id_)},
                "name":{"S":str(name)},
                "salary":{"N":str(salary)},
                "dateOfJoin":{"S":str(dateOfJoin)},
            },
        )
        return resp(200, {"message":"Saved", "id": id_})
    except Exception as e:
        print("POST ERR:", e)
        return resp(500, {"message":"Internal Server Error"})
