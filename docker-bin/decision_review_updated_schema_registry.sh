export TOPIC=BIA_SERVICES_BIE_CATALOG_LOCAL_DECISION_REVIEW_UPDATED_V01

jq -Rs '{ schema: .}' /usr/bin/$TOPIC.avsc > temp-schema.json

if [ ! -f temp-schema.json ]; then
  echo "Failed to create temp schema file"
  exit 1
fi

jq '
  . + {
    schemaType: "AVRO",
    references: [
      {
        "name": "gov.va.bip.cest.decisionreview.avro",
        "subject": "BIA_SERVICES_BIE_CATALOG_LOCAL_DECISION_REVIEW_CREATED_V01",
        "version": 1
      }
    ]
  }
' temp-schema.json > temp-schema-with-references.json

response=$(curl -s -X POST \
  -H "Content-Type:application/vnd.schemaregistry.v1+json" \
  --data @temp-schema-with-references.json \
  http://schema-registry:9021/subjects/$TOPIC/versions)

echo "DecisionReviewUpdated AVRO was uploaded to the Schema-registry successfully"

export SCHEMA_VERSION_UPDATED=$(curl -s -X GET http://schema-registry:9021/subjects/$TOPIC/versions/latest | jq '.version')

rm temp-schema.json temp-schema-with-references.json
