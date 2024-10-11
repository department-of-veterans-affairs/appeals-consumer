FactoryBot.define do
  factory :person_updated_event, class: "Events::PersonUpdatedEvent" do
    message_payload do
      {
        "name": "PersonUpdatedEvent",
        "type": "record",
        "namespace": "gov.va.bip.bie.participant.person",
        "fields": [
          {
            "name": "actorApplicationId",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "actorStation",
            "type": "string"
          },
          {
            "name": "actorUserId",
            "type": "string"
          },
          {
            "name": "birthCityName",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "birthDate",
            "type": [
              "null",
              {
                "type": "int",
                "connect.version": 1,
                "connect.name": "org.apache.kafka.connect.data.Date",
                "logicalType": "date"
              }
            ],
            "default": null
          },
          {
            "name": "birthStateCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "competencyDecisionTypeCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "connectorTs",
            "type": {
              "type": "long",
              "connect.version": 1,
              "connect.name": "org.apache.kafka.connect.data.Timestamp",
              "logicalType": "timestamp-millis"
            }
          },
          {
            "name": "bieTs",
            "type": {
              "type": "long",
              "connect.version": 1,
              "connect.name": "org.apache.kafka.connect.data.Timestamp",
              "logicalType": "timestamp-millis"
            }
          },
          {
            "name": "deathCause",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "deathDate",
            "type": [
              "null",
              {
                "type": "int",
                "connect.version": 1,
                "connect.name": "org.apache.kafka.connect.data.Date",
                "logicalType": "date"
              }
            ],
            "default": null
          },
          {
            "name": "deathDateEnteredDate",
            "type": [
              "null",
              {
                "type": "long",
                "connect.version": 1,
                "connect.name": "org.apache.kafka.connect.data.Timestamp",
                "logicalType": "timestamp-millis"
              }
            ],
            "default": null
          },
          {
            "name": "deathDateUpdatedDate",
            "type": [
              "null",
              {
                "type": "long",
                "connect.version": 1,
                "connect.name": "org.apache.kafka.connect.data.Timestamp",
                "logicalType": "timestamp-millis"
              }
            ],
            "default": null
          },
          {
            "name": "deathNotificationDocumentTypeCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "deathNotificationSourceTypeCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "deathVerificationStatusCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "employmentIndicator",
            "type": %w[
              null
              boolean
            ],
            "default": null
          },
          {
            "name": "employmentOccupation",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "employmentSeriousHandicap",
            "type": %w[
              null
              boolean
            ],
            "default": null
          },
          {
            "name": "entitlementTypeCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "ethnicityTypeCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "fiduciaryDecisionCategoryTypeCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "fileNumber",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "firstName",
            "type": "string"
          },
          {
            "name": "gender",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "journalStatusTypeCode",
            "type": "string"
          },
          {
            "name": "lastName",
            "type": "string"
          },
          {
            "name": "middleName",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "militaryPersonIndicator",
            "type": %w[
              null
              boolean
            ],
            "default": null
          },
          {
            "name": "netWorth",
            "type": %w[
              null
              int
            ],
            "default": null
          },
          {
            "name": "nextOfKinLetterIndicator",
            "type": %w[
              null
              boolean
            ],
            "default": null
          },
          {
            "name": "noSocialSecurityNumberReasonTypeCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "participantId",
            "type": "long"
          },
          {
            "name": "personTypeName",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "potentiallyDangerousIndicator",
            "type": %w[
              null
              boolean
            ],
            "default": null
          },
          {
            "name": "prefix",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "raceTypeName",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "socialSecurityNumber",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "ssnVerificationCode",
            "type": %w[
              null
              string
            ],
            "default": null,
            "doc": "This is the code value for the SSN Verification Status; 
              It uses a number to represent a finite number of options"
          },
          {
            "name": "ssnVerificationName",
            "type": %w[
              null
              string
            ],
            "default": null,
            "doc": "This is the Description associated with the SSN Verification Status; 
              It is an English phrase providing a brief explanation of how the SSN was/was not verified"
          },
          {
            "name": "sourceTs",
            "type": {
              "type": "long",
              "connect.version": 1,
              "connect.name": "org.apache.kafka.connect.data.Timestamp",
              "logicalType": "timestamp-millis"
            }
          },
          {
            "name": "spinaBifidaIndicator",
            "type": %w[
              null
              boolean
            ],
            "default": null
          },
          {
            "name": "suffix",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "taxAbatementCode",
            "type": %w[
              null
              string
            ],
            "default": null
          },
          {
            "name": "totalSubsistenceAmount",
            "type": %w[
              null
              double
            ],
            "default": null
          },
          {
            "name": "veteranIndicator",
            "type": %w[
              null
              boolean
            ],
            "default": null
          },
          {
            "name": "veteranTypeName",
            "type": %w[
              null
              string
            ],
            "default": null
          }
        ]
      }
    end
  end
end
