class Nomad
  livecheck :url => "https://www.nomadproject.io/downloads.html",
            :regex => %r{href="https://releases.hashicorp.com/nomad/([0-9\.]+)}
end
