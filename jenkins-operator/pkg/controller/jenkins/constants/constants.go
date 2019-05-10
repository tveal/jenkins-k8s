package constants

const (
	// OperatorName is a operator name
	OperatorName = "jenkins-operator"
	// DefaultAmountOfExecutors is the default amount of Jenkins executors
	DefaultAmountOfExecutors = 3
	// SeedJobSuffix is a suffix added for all seed jobs
	SeedJobSuffix = "job-dsl-seed"
	// DefaultJenkinsMasterImage is the default Jenkins master docker image
	DefaultJenkinsMasterImage = "jenkins/jenkins:lts"
	// UserConfigurationJobName is the Jenkins job name used to configure Jenkins by groovy scripts provided by user
	UserConfigurationJobName = OperatorName + "-user-configuration"
	// UserConfigurationCASCJobName is the Jenkins job name used to configure Jenkins by Configuration as code yaml configs provided by user
	UserConfigurationCASCJobName = OperatorName + "-user-configuration-casc"
	// DefaultHTTPPortInt32 is the default Jenkins HTTP port
	DefaultHTTPPortInt32 = int32(8080)
	// DefaultSlavePortInt32 is the default Jenkins port for slaves
	DefaultSlavePortInt32 = int32(50000)
)
