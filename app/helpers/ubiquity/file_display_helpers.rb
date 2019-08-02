module Ubiquity
  module FileDisplayHelpers

    # called in app/views/shared/ubiquity/works/_member.html.erb and app/views/shared/ubiquity/file_sets/_media_display.html.erb
    def render_file_or_icon(file_set_presenter)
      # displays zip icon for files with archived format eg zi
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
      elsif ((check_file_is_restricted?(file_set_presenter) == true) || (not file_set_presenter.lease_expiration_date.present?) && (not file_set_presenter.embargo_release_date.present?) && ( file_set_presenter.solr_document['visibility_ssi'] == "open") )
        # displays for logged out users on files without embargo/lease
        # also displays for logged_in users on files with embargo/lease
        render_related_img(file_set_presenter)
      else
        # displays for logged out users on files with embargo/lease
        # '<span class="media-left hidden-xs file_listing_thumbnail mock-thumbnail" ></span>'
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
        file_size_bytes = get_file_size_in_bytes(file_set_presenter.id)
        return "Download temporarily unavailable" if file_size_bytes.zero?
        uuid = params[:parent_id] || params[:id]
        if file_size_bytes < ENV["FILE_SIZE_LIMIT"].to_i
          @file_set_s3_object ||= trigger_api_call_for_s3_url uuid
          if @file_set_s3_object.file_url_hash[file_set_presenter.id].present?
            status = @file_set_s3_object.file_status_hash[file_set_presenter.id]
            if status == "UPLOAD_COMPLETED"
              # link_to 'Download', @file_set_s3_object.file_url_hash[file_set_presenter.id].to_s
              link_to 'Download', main_app.fail_uploads_download_file_path(uuid: uuid, fileset_id: file_set_presenter.id), method: 'post'
            else
              "<a style='text-decoration:none;' href='#' onclick='return false;'>Upload In-Progress</a>".html_safe
            end
          else
            fetch_link_based_on_environment(file_set_presenter, file_size_bytes)
          end
        else
          load_file_from_file_set(file_set_presenter, file_size_bytes)
        end
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
      %w[.zip .zipx .bz2 .gz .dmg .rar .sit .sitx .tar .tar.gz .tgz .tar.Z .tar.bz2 .tbz2 .tar.lzma .tlz .tar.xz .xz .txz tt.tar.xz].freeze
    end

    def check_file_is_restricted?(data)
    # if (current_user.present? && ((current_user.roles_name.include? "admin") || data.depositor == current_user.email || (can? :manage, data)) && (data.lease_expiration_date.present? || data.embargo_release_date.present?) )
      if (current_user.present? && ((current_user.roles_name.include? "admin") || data.depositor == current_user.email || (can? :manage, data)) )
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
      File.extname(name) if name.present?
    end

   #Temporal solution for size passed from https://github.com/curationexperts/riiif/blob/master/app/controllers/riiif/images_controller.rb#L85
    def set_featured_img_size(document)
      thumbnail_path = document.thumbnail_path
      path_array = thumbnail_path.split('/')
      if path_array[4] == "!150,300"
        path_array[4] = "!360,360"
        document[:thumbnail_path_ss] = path_array.join('/')
        document
      else
        document
      end
    end

    #This method is called in app/views/shared/ubiquity/file_sets/_show_details.html.erb and /home/antonio/hyku/hyku/app/views/shared/ubiquity/works/_member.html.erb
    #to fetch create a hash of license and its terms to be loaded in the file details view and the member view
    def fetch_license_hash
      master_hash = {}
      license_hash = YAML.load_file('config/authorities/licenses.yml')
      license_hash["terms"].each do |ele|
        master_hash[ele["id"]] = ele["term"]
      end
      master_hash
    end

    private

      def get_file_size_in_bytes(id)
        file_set = get_file(id)
        pdcm_file_object = file_set.original_file
        # the pdcm file size is in bytes
        return 0 if !pdcm_file_object.present?
        return (pdcm_file_object.try(:size).try(:to_f) )
      end

      def get_file(id)
        FileSet.find(id)
      end

      def fetch_link_based_on_environment(file_set_presenter, file_size_bytes)
        file = get_file(file_set_presenter.id)
        tenant = file.parent.account_cname
        if tenant.present? && (tenant.split('.').include? 'localhost')
          load_file_from_file_set(file_set_presenter, file_size_bytes)
        else
          "<a style='text-decoration:none;' href='#' onclick='return false;'>Download Temporarily Unavailable</a>".html_safe
        end
      end

      def load_file_from_file_set(file_set_presenter, file_size_bytes)
        file_size_in_mb = file_size_bytes/(1000 * 1000)
        file_size_in_gb = (file_size_in_mb/1000)
        #  download_size,   file_path  are passed to message_value for display in contact form
        download_size = file_size_in_gb.round(2)
        file_path = manual_download_path(file_set_presenter.id)
        return link_to('Download', hyrax.download_path(file_set_presenter), title: "Download #{file_set_presenter}", target: "_blank") if file_size_bytes < ENV["FILE_SIZE_LIMIT"].to_f
        message_value = "I would like to access the very large data file (file size #{download_size} GB) held at #{file_path}"
        return link_to('Contact us for download', hyrax.contact_form_index_path(message_value: message_value)) if file_size_bytes > ENV["FILE_SIZE_LIMIT"].to_f
      end

      def manual_download_path(id)
        file = get_file(id)
        tenant = file.parent.account_cname
        # hardcoded to port 3000 so if your localhost uses eg port 8080 to test temporarily change the 3000 to 8080
        if tenant.present?
          if tenant.split('.').include? 'localhost'
            "http://#{tenant}:3000/concern/parent/#{file.parent.id}/file_sets/#{file.id}"
          else
            "https://#{tenant}/concern/parent/#{file.parent.id}/file_sets/#{file.id}"
          end
        end
      end

      def trigger_api_call_for_s3_url uuid
        Ubiquity::ImporterClient.get_s3_url uuid
      end
  end
end
