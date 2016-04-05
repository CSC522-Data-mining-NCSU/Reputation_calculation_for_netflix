Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    :api_file_path => "public/",
    :controller_base_path => "",
    # the URL base path to your API
    # :base_path => "http://api.somedomain.com",
    # if you want to delete all .json files at each generation
    :clean_directory => false,
    # Ability to setup base controller for each api version. Api::V1::SomeController for example.
    #:base_api_controller => ActionController::Base,
    # format
    :formatting => :pretty,
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "Reputation Web Service",
        "description" => "This is a Reputation Web Service.",
        "contact" => "zhu6@ncsu.edu",
        "license" => "Apache 2.0",
        "licenseUrl" => "http://www.apache.org/licenses/LICENSE-2.0.html"
      }
    }
  }
})