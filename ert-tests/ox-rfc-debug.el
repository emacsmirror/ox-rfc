;;
;; February 19 2019, Christian Hopps <chopps@devhopps.com>
;;
;; Copyright (c) 2015 by Christian E. Hopps
;; All rights reserved.

;; This file is NOT part of GNU Emacs.

;;; License:

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;; http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(require 'ob)
(require 'ob-shell)
(require 'ox-rfc)

;;
;; Utility
;;

(defun ox-rfc-load-tidy-xml-as-string (pathname)
  "Pass PATHNAME through tidy and return a string"
  (let ((tidycmd (format "%s %s %s" (executable-find "tidy") ox-rfc-tidy-args pathname)))
    (message "tidy cmd is: '%s'" tidycmd)
    (shell-command-to-string tidycmd)))

(defun test-debug (infile &optional trytidy v2)
  "Check that we produce the expected XML for file named INFILE."
  (let ((ox-rfc-try-tidy trytidy)
        (ox-rfc-xml-version 3)
        (tmpfile (make-temp-file "ert-ox-rfc-actual"))
        xmlout
        (org-export-babel-evaluate t)
        )

    (with-temp-buffer
      (insert-file-contents infile)
      (setq xmlout (ox-rfc-load-tidy-xml-as-string (ox-rfc-export-to-xml))))
    (if (string= "" (org-trim xmlout))
        (error "Empty output from tidy"))
    (with-temp-file tmpfile
      (insert xmlout))))

(ert-deftest xml-yang-01 nil
  "Test YANG XML generation"
  "Check that we produce the expected XML"
  (let ((org-confirm-babel-evaluate nil)
        (org-export-use-babel t))
    (setq org-babel-load-languages '((shell . t) (yang . t)))
    (test-debug "test-yang.org" nil)))
