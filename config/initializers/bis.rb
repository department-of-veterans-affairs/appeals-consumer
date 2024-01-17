require_relative '../../app/controllers/application_controller'
require_relative '../../lib/fakes/bis_service'

BISService = (!ApplicationController.dependencies_faked? ? ExternalApi::BISService : Fakes::BISService)
