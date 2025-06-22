(define (script-fu-lineart-pipeline infile outfile)
  (let* (
          ; Load image
          (image (car (gimp-file-load RUN-NONINTERACTIVE infile infile)))
          (drawable (car (gimp-image-get-active-layer image)))
        )
    ; 1. Desaturate → grayscale
    (gimp-desaturate-full drawable DESATURATE-LUMINOSITY)

    ; 2. Gaussian Blur (15px)
    (plug-in-gauss RUN-NONINTERACTIVE image drawable 15 15 0)

    ; 3. Auto-level
    (gimp-levels-stretch drawable)

    ; 4. Shadows-Highlights
    (plug-in-shadows-highlights RUN-NONINTERACTIVE image drawable 10 42 0 18)

    ; 5. Photocopy (Detail 7, Darkness 50)
    (plug-in-photocopy RUN-NONINTERACTIVE image drawable 7 50)

    ; 6. Median Filter (5px)
    (plug-in-median-run RUN-NONINTERACTIVE image drawable 5)

    ; 7. Diffuse Glow approximation: duplicate + blur + screen
    (let* ((copy (car (gimp-layer-copy drawable TRUE))))
      (gimp-image-add-layer image copy -1)
      (plug-in-gauss RUN-NONINTERACTIVE image copy 5 5 0)
      (gimp-layer-set-mode copy SCREEN-LAYER-MODE)
      (gimp-layer-set-opacity copy 20.0))

    ; 8. Export
    (file-png-save RUN-NONINTERACTIVE image drawable outfile outfile FALSE 9 FALSE FALSE FALSE FALSE FALSE)
    (gimp-image-delete image)
  )
)

(script-fu-register
  "script-fu-lineart-pipeline"
  "Lineart Pipeline"
  "Generates high-quality line art from a photo"
  "Rachel Stein Campos"
  "2025"
  "2025-01-01"
  "*"
  SF-FILENAME "Input File" ""
  SF-FILENAME "Output File" ""
)
