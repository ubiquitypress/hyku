// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
// ubiquityPress added jquery-chosen
//= require chosen-jquery
//= require turbolinks
// Required by Blacklight
//= require blacklight/blacklight
//= require jquery.validate
//= require jquery.validate.additional-methods

// Moved the Hyku JS *above* the Hyrax JS to resolve #1187 (following
// a pattern found in ScholarSphere)
//
//= require ubiquity/search_page
//= require ubiquity/datatable-settings
//= require hyku/groups/per_page
//= require hyku/groups/add_member

//= require hyrax
//= require hyku/groups/uploader
//= require ubiquity/external_services_modal
//= require ubiquity/datacite
//= require ubiquity/custom_required_fields
//= require ubiquity/preselect_institution_by_tenant
//= require ubiquity/title_check
//= require jquery.flot.pie
//= require flot_graph
//= require statistics_tab_manager
//= require blacklight_gallery/default
