export DOMAIN=hyku_host.example.com

# Let's encrypt settings
# Enable or disable obtaining ssl certificates from let's encrypt.
#  Let's encrypt will need to be able to contact your domain
export USE_LETS_ENCRYPT=true
# Obtain an ssl certificate for the domain and each tenant mentioned below
#   Separate each tenant with a space
#   If no tenants, the certificate is obtained just for the domain
export TENANTS="repo1 repo2"
# The email address used to obtain the certificate.
# You will receive emails from let's encrypt regarding the state of your certificates.
export EMAIL=test@digitalnest.co.uk
# This flag is used to obtain a test certificate rather than a real one from let's encrypt.
#   Set to false for production
export USE_TEST_CERT=true

# Shibboleth settings
# Enable or disable shibboleth as an authentication mechanism
export USE_SHIBBOLETH=true
# The tenant that requires shibboleth authentication
export SHIBBOLETH_TENANT=repo1
