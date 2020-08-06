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
//= require ubiquity/jquery-migrate-3.0.0.min
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
// ubiquityPress added jquery-chosen
//= require chosen-jquery
//= require turbolinks
// Required by Blacklight
//= require blacklight/blacklight

// Moved the Hyku JS *above* the Hyrax JS to resolve #1187 (following
// a pattern found in ScholarSphere)
//
//= require ubiquity/search_page
//= require ubiquity/work_page
//= require ubiquity/datatable-settings
//= require hyku/groups/per_page
//= require hyku/groups/add_member
//= require ubiquity/creator
//= require ubiquity/contributor
//= require ubiquity/editor
//= require ubiquity/funder
//= require ubiquity/funder_awards
//= require ubiquity/funder_autocomplete_callback
//= require ubiquity/current_he_institution

//= require hyrax
//= require hyku/groups/uploader
//= require ubiquity/external_services_modal
//= require ubiquity/datacite
//= require ubiquity/custom_required_fields
//= require ubiquity/orcid_isni_validation
//= require ubiquity/preselect_institution_by_tenant
//= require ubiquity/title_check
//= require jquery.flot.pie
//= require flot_graph
//= require statistics_tab_manager
//= require blacklight_gallery/default
