export TOPIC=DecisionReviewCreated
export SCHEMA=$(jq tostring /usr/bin/$TOPIC.avsc)

curl --silent -X POST -H "Content-Type:application/json" -d"{\"schema\":$SCHEMA}" schema-registry:9021/subjects/$TOPIC/versions

