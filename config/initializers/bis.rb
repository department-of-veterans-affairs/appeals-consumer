require_relative '../../app/controllers/application_controller'
require_relative '../../app/services/external_api/bis_service'
require_relative '../../lib/fakes/bis_service'

BISService = (!ApplicationController.dependencies_faked? ? ExternalApi::BISService : Fakes::BISService)