module Ubiquity
  module FileDisplayHelpers

    #called in app/views/shared/ubiquity/works/_member.html.erb and app/views/shared/ubiquity/file_sets/_media_display.html.erb
    def render_file_or_icon(file_set_presenter)
      #displays zip icon for files with archived format eg zi
      if zipped_types.include?  check_file_extension(file_set_presenter.label)
        '<span class="center-block fa fa-file-archive-o fa-5x grey-zip-icon"></span>'
      elsif (check_file_extension(file_set_presenter.label) == ".pdf") && (file_set_presenter.solr_document.thumbnail_path.split('?').last == "file=thumbnail")
        '<span class="center-block fa fa-file-pdf-o fa-5x hidden-xs file_listing_thumbnail" style="color:grey"></span>'
      elsif ([".docx", '.doc'].include? check_file_extension(file_set_presenter.label)) && (file_set_presenter.solr_document.thumbnail_path.split('?').last == "file=thumbnail")
        '<span class="center-block fa fa-file-word-o fa-5x hidden-xs file_listing_thumbnail" style="color:grey"></span>'
      elsif (file_set_presenter.solr_document.thumbnail_path.split('?').last == "file=thumbnail") && ([".docx", '.doc', '.pdf'].exclude? check_file_extension(file_set_presenter.label)) && (zipped_types.exclude? check_file_extension(file_set_presenter.label) )
         '<span class="center-block fa fa-file-o fa-5x hidden-xs file_listing_thumbnail" style="color:grey"></span>'
      elsif ((check_file_is_restricted?(file_set_presenter) == nil) && (file_set_presenter.lease_expiration_date.present?) && (file_set_presenter.embargo_release_date.present?) )
        '<span class="center-block fa fa-file-o fa-5x hidden-xs file_listing_thumbnail" style="color:grey"></span>'
      elsif ((check_file_is_restricted?(file_set_presenter) == true) || (not file_set_presenter.lease_expiration_date.present?) && (not file_set_presenter.embargo_release_date.present?) )
        #displays for logged out users on files without embargo/lease
        #also displays for logged_in users on files with embargo/lease
        render_thumbnail_tag(file_set_presenter)
      else
        #displays for logged out users on files with embargo/lease
        #'<span class="media-left hidden-xs file_listing_thumbnail mock-thumbnail" ></span>'
        '<span class="center-block fa fa-file-o fa-5x hidden-xs file_listing_thumbnail" style="color:grey"></span>'
      end
    end
# <i class="far fa-file"></i>
    def display_file_size(id)
      if id.present?
        file_size_bytes = get_file_size_in_bytes(id)
        return "Being calculated" if file_size_bytes == 0
        file_size_in_kb = (file_size_bytes/1000)
        return "#{file_size_in_kb.round(2)} KB" if file_size_bytes < 5300
        file_size_in_mb = file_size_in_kb/(1000)
        return "#{file_size_in_mb.round(2)} MB" if file_size_in_mb < 100
        file_size_in_gb = (file_size_in_mb/1000) if file_size_in_mb > 100
        return "#{file_size_in_gb.round(2)} GB"
      end
    end

    #called in app/views/shared/ubiquity/file_sets/_show.html.erb and called in app/views/shared/ubiquity/file_sets/_actions.html.erb
    def display_file_download_link_or_contact_form(file_set_presenter)
      if file_set_presenter.id.present?
        file_size_bytes =  get_file_size_in_bytes(file_set_presenter.id)
        return "Download temporarily unavailable" if file_size_bytes == 0
        file_size_in_mb = file_size_bytes/(1000 * 1000)
        file_size_in_gb = (file_size_in_mb/1000)
        #  download_size,   file_path  are passed to message_value for display in contact form
        download_size = file_size_in_gb.round(2)
        file_path = manual_download_path(file_set_presenter.id)
        message_value = "I would like to access the very large data file (file size #{download_size} GB) held at #{file_path}"
        return (link_to('Download', hyrax.download_path(file_set_presenter), title: "Download #{file_set_presenter.to_s}", target: "_blank") ) if file_size_in_gb < 10
        return (link_to('Contact us for download', hyrax.contact_form_index_path(message_value: message_value ) )) if file_size_in_gb > 10
      end
    end

    def manual_download_path(id)
       file = get_file(id)
       tenant = file.parent.account_cname
       #hardcoded to port 3000 so if your localhost uses eg port 8080 to test temporarily change the 3000 to 8080
       if tenant.split('.').include? 'localhost'
          "http://#{tenant}:3000/downloads/#{file.id}"
       else
         "https://#{tenant}/downloads/#{file.id}"
      end
    end

    #receives a file_set when called from views/hyrax/base/_representative_media.html.erb
    #receives a Hyku::FileSetPresenter when called from views/shared/ubiquity/works/_member.html.erb
    #used when work type was passed in
    #  data = data.thumbnail if data.class != Hyku::FileSetPresenter
    #
    #Change zip to .zip and others too because calling file.format on a thumbnail in production
    #returned *zip (ZIP Format)* instead of zip
    def zipped_types
      %w[.zip .zipx .bz2 .gz .dmg .rar .sit .sitx .tar .tar.gz .tgz .tar.Z .tar.bz2 .tbz2 .tar.lzma .tlz .tar.xz .xz .txz].freeze
    end

    def check_file_is_restricted?(data)
      if (current_user.present? && ((current_user.roles_name.include? "admin") || data.depositor == current_user.email || (can? :manage, data)) && (data.lease_expiration_date.present? || data.embargo_release_date.present?))
        true
      end
    end

    #the method below ase well as zipped_types & check_file_is_resticted are called in multiple files:
    #app/views/shared/ubiquity/file_sets/_restricted_media.html.erb
    #app/views/shared/ubiquity/_thumbnail_icons.html.erb
    #app/views/shared/ubiquity/_thumbnail_icons_with_restrictions.html.erb
    #app/views/shared/ubiquity/search_display/_search_thumbnail.html.erb
    #app/views/shared/ubiquity/works/_member.html.erb
    def check_file_extension(name)
      File.extname(name)
    end

    def set_featured_img_size(document)
      thumbnail_path = document.thumbnail_path
      path_array = thumbnail_path.split('/')
      if path_array[4] == "!150,300"
        path_array[4] = "!360,360"
        document[:thumbnail_path_ss] =   path_array.join('/')
        document
      else
        document
      end

    end


    private

    def get_file_size_in_bytes(id)
      #@file_set = FileSet.find(id)
      @file_set = get_file(id)
      pdcm_file_object = @file_set.original_file
      #the pdcm file size is in bytes
      return (pdcm_file_object.try(:size).try(:to_f) ) if pdcm_file_object.present?
      return 0 if !pdcm_file_object.present?
    end

    def get_file(id)
      if id.present?
        @file_set ||= FileSet.find(id)
      end

    end

  end
end
