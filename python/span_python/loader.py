import numpy as np
from model import Model
from pygltflib import GLTF2


def parse_gltf(model_filename: str) -> Model | None:
    model = GLTF2.load(model_filename)

    if model is None:
        print(f"[ERROR]: Coult not load gltf model: {model_filename}")
        return None
    
    binary = model.binary_blob()
    result_model = Model()

    for mesh in model.meshes:
        for primitive in mesh.primitives:
            uv_accessor = model.accessors[primitive.attributes.TEXCOORD_0]
            uv_bufferview = model.bufferViews[uv_accessor.bufferView]

            vertex_accessor = model.accessors[primitive.attributes.POSITION]
            vertex_bufferview = model.bufferViews[vertex_accessor.bufferView]

            tri_accessor = model.accessors[primitive.indices]
            tri_bufferview = model.bufferViews[tri_accessor.bufferView]

            uvs = np.frombuffer(
                binary[
                    uv_bufferview.byteOffset + uv_accessor.byteOffset:
                    uv_bufferview.byteOffset + uv_bufferview.byteLength
                ],
                dtype="float32",
                count=uv_accessor.count * 2,
            ).reshape((-1, 2))
            vertices = np.frombuffer(
                binary[
                    vertex_bufferview.byteOffset + vertex_accessor.byteOffset:
                    vertex_bufferview.byteOffset + vertex_bufferview.byteLength
                ],
                dtype="float32",
                count=vertex_accessor.count * 3,
            ).reshape((-1, 3))
            triangles = np.frombuffer(
                binary[
                    tri_bufferview.byteOffset + tri_accessor.byteOffset:
                    tri_bufferview.byteOffset + tri_bufferview.byteLength
                ],
                dtype="uint8",
                count=tri_accessor.count,
            ).reshape((-1, 3))

            result_model.add_mesh(vertices, uvs, triangles)

    return result_model