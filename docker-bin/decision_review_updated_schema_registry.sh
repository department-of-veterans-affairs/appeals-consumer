export TOPIC=BIA_SERVICES_BIE_CATALOGUE_LOCAL_DECISION_REVIEW_UPDATED_V01


jq -Rs '{ schema: .}' /usr/bin/$TOPIC.avsc > temp-schema.json

if [ ! -f temp-schema.json ]; then
  echo "Failed to create temp schema file"
  exit 1
fi

curl -s -X POST -H "Content-Type:application/vnd.schemaregistry.v1+json" --data @temp-schema.json http://schema-registry:9021/subjects/$TOPIC/versions > /dev/null

echo "DecisionReviewUpdated AVRO was uploaded to the Schema-registry successfully"

export SCHEMA_VERSION=$(curl -s -X GET http://schema-registry:9021/subjects/$TOPIC/versions/latest | jq '.version')

rm temp-schema.json
