(defun my-org/play-sound-file-async (file)
  "Plys with some overhead, but at least doesn't freeze Emacs."
  (let ((command (car command-line-args)))
    (start-process "play-sound-file-async" nil command "-Q" "--batch" "--eval"
                   (format "(play-sound-file \"%s\")" file))))

(defun my-org/org-pomodoro-play-sound-async (type)
  "Play an audio file specified by TYPE (:pomodoro, :short-break, :long-break)."
  (let ((sound (org-pomodoro-sound type))
        (args (org-pomodoro-sound-args type)))
    (my-org/play-sound-file-async sound)
    ))
