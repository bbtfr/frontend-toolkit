require 'thor'
require 'fileutils'

class UpdateCLI < Thor
  desc "all", "update all the components"
  def all
    bower
    backbone
    underscore
    bootstrap
    ratchet
    jquery
    zepto
    react
  end

  desc "bower", "update bower components"
  def bower
    FileUtils.cd GEM_PATH do
      update :all
    end
  end

  desc "backbone", "update backbone from bower components"
  def backbone
    update "backbone"
    copy "backbone/backbone.js", "javascripts"
  end

  desc "underscore", "update underscore from bower components"
  def underscore
    update "underscore"
    copy "underscore/underscore.js", "javascripts"
  end

  desc "bootstrap", "update bootstrap from bower components"
  def bootstrap
    update "bootstrap-sass"
    copy "bootstrap-sass/assets/javascripts/bootstrap/*", "javascripts/bootstrap"
    copy "bootstrap-sass/assets/stylesheets/*", "stylesheets"
    copy "bootstrap-sass/assets/fonts/*", "fonts"
  end

  desc "ratchet", "update ratchet from bower components"
  def ratchet
    update "ratchet"
    copy "ratchet/js/*.js", "javascripts/ratchet"
    copy "ratchet/sass/*.scss", "stylesheets/ratchet"
    copy "ratchet/fonts/*", "fonts/ratchet"
    replace "stylesheets/ratchet/ratchicons.scss", "url('../fonts/", "font-url('ratchet/"
  end

  desc "jquery", "update jquery from bower components"
  def jquery
    update "jquery"
    copy "jquery/src/*", "javascripts/jquery"
    copy "jquery/dist/jquery.js", "javascripts"
  end

  desc "zepto", "update zepto from github repository"
  def zepto
    download "madrobby/zepto"
    copy "zepto-master/src/*", "javascripts/zepto"
  end

  desc "react", "update react from bower components"
  def react
    update "react"
    copy "react/react.js", "javascripts"
    copy "react/react-with-addons.js", "javascripts"
  end

  private

    GEM_PATH = File.expand_path '../..', File.dirname(__FILE__)
    ASSETS_PATH = File.join GEM_PATH, 'assets'
    COMPONENTS_PATH = File.join ASSETS_PATH, 'components'

    def run *cmds
      command = cmds.join(" ")
      say_status "run", command
      unless system command
        say_status "error", "Something wrong with `#{command}'", :red
        exit -1
      end
    end

    def copy src, dist
      say_status "copy", "components/#{src} to #{dist}"
      glob = Dir[File.join COMPONENTS_PATH, src]
      dist = File.join ASSETS_PATH, dist
      unless glob.any?
        say_status "error", "No files matching `#{src}'", :red
        exit -1
      end
      FileUtils.mkdir_p dist
      FileUtils.cp_r glob, dist
    end

    def replace file, src, dist
      say_status "replace", "#{file} `#{src}' to `#{dist}'"
      file = File.join ASSETS_PATH, file
      File.open file, "r+" do |file|
        text = file.read
        unless text[src]
          say_status "error", "No text matching `#{src}'", :red
          exit -1
        end
        text.gsub! src, dist
        file.rewind
        file.puts text
      end
    end

    def download url
      say_status "download", "#{url}"
      dist = url.split("/").last
      url = "https://github.com/#{url}/archive/master.zip"
      FileUtils.cd File.join ASSETS_PATH, 'components' do
        FileUtils.rm_f "master.zip"
        system "wget -q #{url}"
        FileUtils.rm_rf "#{dist}-master"
        system "unzip -oq master.zip"
        FileUtils.rm_f "master.zip"
      end
    end

    def update package
      if package == :all
        run :bower, :update
        @already_update = true
      elsif !@already_update
        run :bower, :update, package
      end
    end
end
