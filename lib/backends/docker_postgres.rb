module Backends
  class DockerPostgres < Thor
    desc "up", "docker run --rm"
    def up
      stop
      exec "docker run --rm #{opts}"
    end

    desc "start", "docker run --detach"
    def start
      stop
      system "docker run --detach #{opts}", exception: true
    end

    desc "stop", "docker rm --force"
    def stop
      system "docker rm --force #{name}", exception: true
    end

    desc "rm", "docker rm --force --volumes"
    def rm
      system "docker rm --force --volumes #{name}", exception: true
    end

    private

    def opts
      [
        "--name #{name}",
        "--env POSTGRES_USER='#{user}' --env POSTGRES_PASSWORD='#{password}'",
        "--volume #{volume}:/var/lib/postgresql/data",
        "--publish #{port}:5432",
        image
      ].join(" ")
    end

    def project_name = Rails.application.class.module_parent_name.underscore
    def name = "#{project_name}_postgres"
    def db_conf = Rails.configuration.database_configuration[Rails.env]
    def user = db_conf["username"]
    def password = db_conf["password"]
    def port = db_conf["port"]
    def volume = name
    def image = "postgres:16"
  end
end

Backends::DockerPostgres.start ARGV
