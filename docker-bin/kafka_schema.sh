export TOPIC=DecisionReviewCreated

jq -Rs '{ schema: .}' /usr/bin/$TOPIC.avsc > temp-schema.json

if [ ! -f temp-schema.json ]; then
  echo "Failed to create temp schema file"
  exit 1
fi

curl -s -X POST -H "Content-Type:application/vnd.schemaregistry.v1+json" --data @temp-schema.json http://schema-registry:9021/subjects/$TOPIC/versions > /dev/null

echo "Avro was uploaded to the Schema-registry successfully"

rm temp-schema.json
