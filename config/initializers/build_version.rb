# This file is created in the deployed container through the appeals deployment repo
# https://github.com/department-of-veterans-affairs/appeals-deployment/blob/12e11cb88c9eafd0cb65ee15d603e483902aebca/ansible/roles/caseflow-consumer/tasks/main.yml#L42
file_path = Rails.root + "config/build_version.yml"
raw_config = File.exist?(file_path) ? File.read(file_path) : ""
config = YAML.load(raw_config)
Rails.application.config.build_version = config ? config.symbolize_keys : nil