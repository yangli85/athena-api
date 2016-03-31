module Common
  class MissingEnvironmentVariablesError < StandardError;
  end

  class EnvironmentVariables
    attr_reader :required_environment_variables

    def initialize env_variables
      @required_environment_variables = env_variables
    end

    def self.check variables
      new(variables).check
    end

    def check
      if missing_environment_variables.any?
        message = "Missing the following required environment variables: #{missing_environment_variables.join(", ")}"
        raise MissingEnvironmentVariablesError.new message
      end
    end

    private

    def missing_environment_variables
      required_environment_variables.select { |var| env_var_not_set?(var) }
    end

    def env_var_not_set? env_var
      ENV["#{env_var}"].nil? || ENV["#{env_var}"].empty?
    end
  end
end
