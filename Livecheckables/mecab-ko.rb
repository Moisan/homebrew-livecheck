class MecabKo
  livecheck :url   => "https://bitbucket.org/eunjeon/mecab-ko/downloads/",
            :regex => /href=.*?mecab-(\d+(?:\.\d+)+-ko-\d+(?:\.\d+)+)\.t/
end