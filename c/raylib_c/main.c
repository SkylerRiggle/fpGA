#include <raylib/raylib.h>

int main(void) {
	SetConfigFlags(FLAG_WINDOW_RESIZABLE);
	SetWindowMinSize(320, 240);

	InitWindow(800, 450, "Raylib C");

	HideCursor();
	DisableCursor();

	Camera3D camera = { 0 };
	camera.position = (Vector3){ 0.0f, 0.0f, 0.0f };
	camera.target = (Vector3){ 0.0f, 0.0f, 1.0f };
	camera.up = (Vector3){ 0.0f, 1.0f, 0.0f };
	camera.fovy = 60.0f;
	camera.projection = CAMERA_PERSPECTIVE;

	Model scene_model = LoadModel("./assets/sponza/sponza.glb");

	while (!WindowShouldClose()) {
		UpdateCamera(&camera, CAMERA_FREE);

		BeginDrawing();

		ClearBackground(BLACK);

		BeginMode3D(camera);
		DrawModel(
			scene_model,
			(Vector3){ 0.0f, 0.0f, 0.0f },
			1.0f,
			WHITE
		);
		EndMode3D();

		DrawFPS(0, 0);

		EndDrawing();
	}

	UnloadModel(scene_model);
	CloseWindow();

	return 0;
}