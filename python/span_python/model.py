import numpy as np


class Model:
    __vertices: list[any]
    __uvs: list[any]
    __triangles: list[any]

    __mesh_count: int = 0

    def __init__(self) -> None:
        self.__vertices = []
        self.__uvs = []
        self.__triangles = []
        self.__mesh_count = 0

    def add_mesh(
            self,
            vertices: np.ndarray[tuple[int, int], np.dtype[np.float32]],
            uvs: np.ndarray[tuple[int, int], np.dtype[np.float32]],
            triangles: np.ndarray[tuple[int, int], np.dtype[np.uint8]]
        ) -> None:
        self.__vertices.append(vertices)
        self.__uvs.append(uvs)
        self.__triangles.append(triangles)
        self.__mesh_count += 1

    def num_meshes(self) -> int:
        return self.__mesh_count