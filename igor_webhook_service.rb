# igor_webhook_service.rb
require 'sinatra'
require 'json'
require 'octokit'

=begin
EDUCATIONAL REFERENCES: 
- https://docs.github.com/en/free-pro-team@latest/developers/webhooks-and-events/securing-your-webhooks
- https://octokit.github.io/octokit.rb/Octokit/Client/Repositories.html#protect_branch-instance_method
- https://github.community/t/user-cannot-access-branch-protection-endpoint-via-api/14612/3
- https://organizer.gitconsensus.com/#/
- https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#branches
=end

post '/' do
    payload_body = request.body.read
    verify_signature(payload_body)
	payload = JSON.parse(params[:payload])
    if request.env['HTTP_X_GITHUB_EVENT'] == 'repository' && payload["action"] == 'created'
      protect(payload)
	else
      return halt 202, "Even not present"
    end
end

def verify_signature(payload_body)
	signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['SECRET_TOKEN'], payload_body)
	return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
end

def protect(pay_load)
	opts = {"accept": "application/vnd.github.luke-cage-preview+json",
		"enforce_admins": true,
		"required_pull_request_reviews": {
	    	"required_approving_review_count": 1
	  	}
	}

	repo = pay_load["repository"]["full_name"]
	puts "Working on repository: #{repo}"
	
	# Authenticate
	puts "Authenticating with GitHub API"
	client_inst = Octokit::Client.new(:login => 'igorgvero', :password => ENV['GH_API_TOKEN'])

	# Protect
	puts "Adding protection"
	client_inst.protect_branch(repo, "main", opts)

	# Create the issue and notify
	puts "Opening an issue and notifying"
	issue = client_inst.create_issue(repo,"Main branch protection enabled","@igorgvero Main branch is now safe")

	# Close the issue
	puts "Closing an issue"
	client_inst.close_issue(repo, issue["number"])

end

get '/' do
  'Only webhook POST requests accepted!'
end