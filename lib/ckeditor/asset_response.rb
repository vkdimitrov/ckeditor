require 'action_view/helpers/tag_helper'
require 'action_view/helpers/javascript_helper'

module Ckeditor
  class AssetResponse
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::JavaScriptHelper

    FUNCTION = 'window.parent.CKEDITOR.tools.callFunction'.freeze
    JSON_TYPE = 'json'.freeze

    attr_reader :asset, :params

    def initialize(asset, request)
      @asset = asset
      @request = request
      @params = request.params

      @asset.data = Ckeditor::Http.normalize_param(file, @request)
    end

    def json?
      params[:responseType] == JSON_TYPE
    end

    def ckeditor?
      !params[:CKEditor].blank?
    end

    def file
      !(ckeditor? || json?) ? params[:qqfile] : params[:upload]
    end

    def current_mode
      @current_mode ||= extract_mode
    end

    def success(relative_url_root = nil, size_prefix = nil)
      send("success_#{current_mode}", relative_url_root, size_prefix)
    end

    def errors
      send("errors_#{current_mode}")
    end

    private

    def success_json(_relative_url_root = nil, size_prefix = nil)
      asset_url = asset.url
      asset_url = change_size_prefix(asset.url, size_prefix) if size_prefix

      {
        json: { uploaded: 1, fileName: asset.filename, url: asset_url }.to_json
      }
    end

    def success_ckeditor(relative_url_root = nil, size_prefix = nil)
      asset_url = asset_url(relative_url_root)
      asset_url = change_size_prefix(asset_url, size_prefix) if size_prefix

      { html: javascript_tag("#{FUNCTION}(#{params[:CKEditorFuncNum]}, '#{asset_url}');") }
    end

    def success_default(_relative_url_root = nil, _size_prefix = nil)
      {
        json: asset.to_json(only: [:id, :type])
      }
    end

    def errors_json
      {
        json: { uploaded: 0, error: { message: error_message } }.to_json
      }
    end

    def errors_ckeditor
      {
        html: javascript_tag("#{FUNCTION}(#{params[:CKEditorFuncNum]}, null, '#{error_message}');")
      }
    end

    def errors_default
      {
        json: { message: error_message }.to_json
      }
    end

    def error_message
      Ckeditor::Utils.escape_single_quotes(asset.errors.full_messages.first)
    end

    def asset_url(relative_url_root)
      url = Ckeditor::Utils.escape_single_quotes(asset.url_content)

      if URI(url).relative?
        "#{relative_url_root}#{url}"
      else
        url
      end
    end

    def extract_mode
      if json?
        :json
      elsif ckeditor?
        :ckeditor
      else
        :default
      end
    end

    def change_size_prefix(asset_url, size_prefix)
      asset_url.sub(/original_/, "#{size_prefix}_")
    end
  end
end
