# Set the topic name
export TOPIC=BIA_SERVICES_BIE_CATALOG_LOCAL_PARTICIPANT_PERSON_UPDATED_V01

# Define the path to the AVRO schema file
SCHEMA_FILE="/usr/bin/$TOPIC.avsc"

# Check if the schema file exists
if [ ! -f "$SCHEMA_FILE" ]; then
  echo "Schema file $SCHEMA_FILE does not exist"
  exit 1
fi

# Convert the AVRO schema file to JSON format
jq -Rs '{ schema: .}' "$SCHEMA_FILE" > temp-schema.json

# Check if the temp-schema.json file was created successfully
if [ ! -s temp-schema.json ]; then
  echo "Failed to create temp schema file"
  exit 1
fi

# Define the schema registry URL
SCHEMA_REGISTRY_URL="http://schema-registry:9021"

# Upload the schema to the schema registry
UPLOAD_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type:application/vnd.schemaregistry.v1+json" \
  --data @temp-schema.json "$SCHEMA_REGISTRY_URL/subjects/$TOPIC/versions")

# Check if the upload was successful
if [ "$UPLOAD_RESPONSE" -ne 200 ]; then
  echo "Failed to upload schema to the schema registry"
  rm temp-schema.json
  exit 1
fi

echo "PersonUpdated AVRO was uploaded to the Schema-registry successfully"

# Retrieve the latest schema version
SCHEMA_VERSION=$(curl -s -X GET "$SCHEMA_REGISTRY_URL/subjects/$TOPIC/versions/latest" | jq -r '.version')

# Check if the schema version was retrieved successfully
if [ -z "$SCHEMA_VERSION" ]; then
  echo "Failed to retrieve the latest schema version"
  rm temp-schema.json
  exit 1
fi

echo "Latest PersonUpdated schema version: $SCHEMA_VERSION"

# Clean up the temporary schema file
rm temp-schema.json
