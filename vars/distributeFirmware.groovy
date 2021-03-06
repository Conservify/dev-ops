#!/usr/bin/env groovy

def call(Map parameters = [:]) {
	def command = "fktool --scheme https"

	if (parameters.directory) {
		command += " --firmware-directory " + parameters.directory
	}

	if (parameters.file) {
		command += " --firmware-file " + parameters.file
	}

	if (parameters.module) {
		command += " --module " + parameters.module
	}

	if (parameters.profile) {
		command += " --profile " + parameters.profile
	}

	if (parameters.email) {
		command += " --email " + parameters.email
	}

	if (parameters.password) {
		command += " --password " + parameters.password
	}

	if (parameters.version) {
		command += " --version " + parameters.version
	}

	echo command + " --host api.fkdev.org"
	sh command + " --host api.fkdev.org"

	echo command + " --host api.fieldkit.org"
	sh command + " --host api.fieldkit.org"
}
