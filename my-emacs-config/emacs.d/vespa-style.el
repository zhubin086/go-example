;;; vespa-style.el --- Provides a C++ style for VESPA code
;;
;; Copyright © 1997-2004 Yahoo! Inc. All Rights Reserved.
;;
;; This software is the confidential and proprietary information of
;; Yahoo! Inc. ("Confidential Information"). You shall not
;; disclose such Confidential Information and shall use it only in
;; accordance with the terms of the license agreement you entered into
;; with Yahoo! Inc.
;;
;; YAHOO MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF
;; THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
;; TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
;; PARTICULAR PURPOSE, OR NON-INFRINGEMENT. YAHOO SHALL NOT BE LIABLE FOR
;; ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
;; DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
;;
;; Author: Stig S. Bakken <stig@yahoo-inc.com>
;; This file is not part of GNU Emacs.
;;
;; $Id: vespa-style.el,v 1.12 2005/02/16 10:21:47 jarll Exp $
;;

;;; Commentary:

;; This library provides a cc-mode style definition that implement
;; parts of the VESPA Code Conventions.
;;
;; Your system could already be set up for VESPA style, if so you
;; don't have to do anything to use it.
;;
;; To check if your emacs has been set up automatically, type
;; "C-x v c-mode-common-hook", and look for vespa-c-mode-hook.
;; If found, you don't have to do anything.
;;
;; If not found, send a mail to the author and have him set up your
;; system Emacs environment, or if you want to be in control, store
;; this file in ~/elisp/vespa-style.el, and add this to your .emacs
;; file:
;;
;; (add-to-list 'load-path "~/elisp")
;; (require 'vespa-style)
;; (add-hook 'c-mode-common-hook 'vespa-c-mode-hook)
;;

;;; Code:

(defconst vespa-c-style
;(setq vespa-c-style
  '((c-basic-offset . 4)
    (vespa-paren-lineup-threshold . 40)
    (indent-tabs-mode . nil)
    (c-comment-only-line-offset . 0)
    (c-offsets-alist
     . ((label . 0)
	(case-label . 0)
	(substatement . +)
	(substatement-open . 0)
	(namespace-open . 0)
	(namespace-close . 0)
	(innamespace . 0)
	(inline-open . 0)
        (inher-cont . c-lineup-multi-inher)
        (statement-cont . c-lineup-math)
        (arglist-cont-nonempty . vespa-c-lineup-arglist-intro-after-paren)
        (arglist-intro . ++)
        (arglist-close . c-lineup-arglist)
	))
    ))
(c-add-style "vespa" vespa-c-style)

(defun vespa-c-lineup-arglist-intro-after-paren (langelem)
  "Line up a line just after the open paren of the surrounding paren or
brace block.

Works with: defun-block-intro, brace-list-intro,
statement-block-intro, statement-case-intro, arglist-intro."
  (let* ((langelem-col (c-langelem-col langelem t))
         (ce-curcol (save-excursion
                      (backward-up-list 1)
                      (beginning-of-line)
                      (skip-chars-forward " \t" (c-point 'eol))
                      (current-column)))
         (full-indent (c-lineup-arglist-intro-after-paren langelem))
         (goal-col (+ langelem-col (if (vectorp full-indent) (car (append full-indent nil)) full-indent))))
    (progn
      (if (> goal-col vespa-paren-lineup-threshold)
          (* 2 c-basic-offset)
        full-indent))))

(defun vespa-project-p ()
  "Hook function for cc-mode that sets c-file-style to \"vespa\"
if CVS administrative file indicate that the current file belongs
to a VESPA project."
  (save-excursion
    (if (and (or (eq major-mode 'c++-mode) (eq major-mode 'c-mode))
             (file-readable-p "CVS/Root") (file-readable-p "CVS/Repository"))
        (let*
            ((cvs-root-buffer (find-file-read-only "CVS/Root"))
             (is-trd-cvs
              (or (looking-at "^cvs\.trondheim\.corp\.yahoo\.com:/cvs$")
                  (looking-at "^cvs\.trondheim\.corp:/cvs$")
                  (looking-at "^cvs\.trondheim:/cvs$")
                  (looking-at "^cvs:/cvs$")))
             (cvs-repo-buffer (find-file-read-only "Repository"))
             (is-vespa-module
              (and is-trd-cvs
		   (not (looking-at "^mmsearch/")))))
          (kill-buffer cvs-root-buffer)
          (kill-buffer cvs-repo-buffer)
          is-vespa-module))))

(defun vespa-c-mode-hook ()
  (and (vespa-project-p) (c-set-style "vespa")))

(provide 'vespa-style)

;; vespa-style.el ends here

