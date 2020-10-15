#+ Demonstrates the usage of a URL based webcomponent
#+ when using pdfjs.js due to the side effects of GDC-4402
#+ (PDFs only sometime showing up)
IMPORT util
IMPORT os
MAIN
  DEFINE w, err, creator, author, gasloc, origin, url STRING
  CALL check_prerequisites()
  OPEN FORM f FROM "pdfjs"
  DISPLAY FORM f
  IF (gasloc
    := fgl_getenv("FGL_VMPROXY_WEB_COMPONENT_LOCATION")) IS NOT NULL THEN
    LET url = gasloc, "/web/web.html"
  ELSE
    --direct mode:
    --we use the hidden component based webcomponent to retrieve the URL
    --for the URL based component
    --this is admittedly a very ugly hack
    DISPLAY "direct mode:need hack"
    CALL ui.interface.frontcall(
      "webcomponent", "call", ["formonly.w2", "getUrl"], [url])
  END IF
  DISPLAY "url of url based compo:", url
  MESSAGE "url of url based compo:", url
  DISPLAY url TO w
  MENU
    BEFORE MENU
      CALL DIALOG.setActionHidden("error", 1)
      CALL displayPDF("hello.pdf")
    ON ACTION cancel
      EXIT MENU
    ON ACTION radstation ATTRIBUTE(TEXT = "Show radstation.pdf")
      CALL displayPDF("radstation.pdf")
    ON ACTION hello ATTRIBUTE(TEXT = "Show hello.pdf")
      CALL displayPDF("hello.pdf")
    ON ACTION showcreator ATTRIBUTE(TEXT = "Retrieve creator")
      CALL ui.interface.frontcall(
        "webcomponent", "call", ["formonly.w", "getCreator"], [creator])
      MESSAGE "creator:", creator
    ON ACTION showauthor ATTRIBUTE(TEXT = "Retrieve author")
      CALL ui.interface.frontcall(
        "webcomponent", "call", ["formonly.w", "getAuthor"], [author])
      MESSAGE "author:", author
    ON ACTION error
      CALL ui.interface.frontcall(
        "webcomponent", "call", ["formonly.w", "getError"], [err])
      ERROR SFMT("Failed at js side with:%1", err)
    ON ACTION showenv ATTRIBUTE(TEXT = "Show FGL env")
      ERROR "public_dir:",
        fgl_getenv("FGL_PUBLIC_DIR"),
        ",\npublic_url_prefix:",
        fgl_getenv("FGL_PUBLIC_URL_PREFIX"),
        ",\npublic_image:",
        fgl_getenv("FGL_PUBLIC_IMAGEPATH"),
        ",\npwd:",
        os.Path.pwd(),
        ",\nFGL_PRIVATE_DIR:",
        fgl_getenv("FGL_PRIVATE_DIR")
      DISPLAY "public_dir:",
        fgl_getenv("FGL_PUBLIC_DIR"),
        ",\npublic_url_prefix:",
        fgl_getenv("FGL_PUBLIC_URL_PREFIX"),
        ",\npublic_image:",
        fgl_getenv("FGL_PUBLIC_IMAGEPATH"),
        ",\npwd:",
        os.Path.pwd(),
        ",\nFGL_PRIVATE_DIR:",
        fgl_getenv("FGL_PRIVATE_DIR")
      RUN "echo `env | grep FGL`"
  END MENU
END MAIN

FUNCTION displayPDF(fname)
  DEFINE fname, remoteName STRING
  DISPLAY fname TO file
  LET remoteName = ui.Interface.filenameToURI(fname)
  DISPLAY remoteName TO url
  CALL ui.interface.frontcall(
    "webcomponent", "call", ["formonly.w", "displayPDF", remoteName], [])
END FUNCTION

FUNCTION check_prerequisites()
  DEFINE code INT
  RUN "curl --help" RETURNING code
  IF code THEN
    DISPLAY "SKIP test for platforms not having curl"
    EXIT PROGRAM 1
  END IF
  RUN "patch --help" RETURNING code
  IF code THEN
    DISPLAY "SKIP test for platforms not having patch"
    EXIT PROGRAM 1
  END IF
  RUN "make download_and_patch" RETURNING code
  IF code THEN
    DISPLAY "SKIP test: download and patch failed"
    EXIT PROGRAM 1
  END IF
END FUNCTION
