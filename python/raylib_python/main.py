import raylib as rb

def main(scene_model_filename: bytes) -> None:
    rb.SetConfigFlags(rb.FLAG_WINDOW_RESIZABLE)
    rb.SetWindowMinSize(320, 240)

    rb.InitWindow(800, 450, b"Raylib Python")

    rb.HideCursor()
    rb.DisableCursor()

    camera = rb.ffi.new("struct Camera3D *", [
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 1.0],
        [0.0, 1.0, 0.0],
        60.0,
        rb.CAMERA_PERSPECTIVE
    ])

    scene_model = rb.LoadModel(scene_model_filename)

    while (not rb.WindowShouldClose()):
        rb.UpdateCamera(camera, rb.CAMERA_FREE)

        rb.BeginDrawing()

        rb.ClearBackground(rb.BLACK)

        rb.BeginMode3D(camera[0])
        rb.DrawModel(
            scene_model,
            (0.0, 0.0, 0.0),
            1.0,
            rb.WHITE
        )
        rb.EndMode3D()

        rb.DrawFPS(0, 0)

        rb.EndDrawing()

    rb.UnloadModel(scene_model)
    rb.CloseWindow()

if __name__ == "__main__":
    main(b"./assets/sponza/sponza.glb")