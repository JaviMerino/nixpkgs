{
  lib
  , fetchzip
  , python3Packages
  #, rpm
}:

python3Packages.buildPythonApplication rec {
  pname = "koji";
  version = "1.34.0";
  src = fetchzip {
    url = "https://pagure.io/koji/archive/koji-${version}/koji-koji-${version}.tar.gz";
    hash = "sha256-pUAfg/wS8Wxzj9Udhr/R+QEQvQSdRr8yGFqbDR7pfT0=";
  };
  propagatedBuildInputs = with python3Packages; [
    dateutil
    requests
    requests-gssapi
    six
  ];

  doCheck=false;

  meta = with lib; {
    description = "A flexible, secure, and reproducible way to build RPM-based software.";
    homepage = "https://pagure.io/koji/";
    maintainers = with maintainers; [ javimerino ];
    license = licenses.lgpl21Only;
    platforms = platforms.all;
  };
}
