import loader


def main(scene_model_filename: str, screen_width: int, screen_height: int):
    name_parts = scene_model_filename.split(".")
    assert len(name_parts) > 0

    scene_model: loader.Model | None = None
    match name_parts[-1]:
        case "gltf" | "glb":
            scene_model = loader.parse_gltf(scene_model_filename)
        case _:
            print("UNKNOWN MODEL FORMAT (",  name_parts[-1], ')')

    assert scene_model is not None

if __name__ == "__main__":
    main("./assets/sponza/sponza.glb", 1280, 720)