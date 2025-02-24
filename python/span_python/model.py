import numpy as np
from typing import Generator


class Vertex:
    x: float
    y: float
    z: float

    u: float
    v: float

    def __init__(self) -> None:
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0

        self.u = 0.0
        self.v = 0.0

class Mesh:
    __vertices: list[Vertex]
    __triangles: list[tuple[int, int, int]]
    __tex_idx: int

    def __init__(
            self,
            vertices: np.ndarray[tuple[int, int, int], np.dtype[np.float32]],
            uvs: np.ndarray[tuple[int, int], np.dtype[np.float32]],
            triangles: np.ndarray[tuple[int, int, int], np.dtype[np.uint8]],
            tex_idx: int
        ):
        assert len(vertices) == len(uvs)

        self.__vertices = [Vertex() for _ in range(vertices.size)]
        self.__triangles = [(0, 0, 0) for _ in range(triangles.size)]
        self.__tex_idx = tex_idx

        for idx in range(len(vertices)):
            old_vertex = vertices[idx]
            old_uv = uvs[idx]
            vertex = self.__vertices[idx]

            vertex.x = old_vertex[0]
            vertex.y = old_vertex[1]
            vertex.z = old_vertex[2]

            vertex.u = old_uv[0]
            vertex.v = old_uv[1]

        for idx in range(len(triangles)):
            old_tri = triangles[idx]
            self.__triangles[idx] = (
                old_tri[0],
                old_tri[1],
                old_tri[2]
            )

    def get_tex_id(self) -> int:
        return self.__tex_idx

    def IterateTriangles(self) -> Generator[tuple[Vertex, Vertex, Vertex], None, None]:
        for tri in self.__triangles:
            yield (
                self.__vertices[tri[0]],
                self.__vertices[tri[1]],
                self.__vertices[tri[2]]
            )

class Model:
    __meshes: list[Mesh]
    __textures: dict[int, any]

    def __init__(self) -> None:
        self.__meshes = []
        self.__textures = []

    def add_mesh(
            self,
            vertices: np.ndarray[tuple[int, int, int], np.dtype[np.float32]],
            uvs: np.ndarray[tuple[int, int], np.dtype[np.float32]],
            triangles: np.ndarray[tuple[int, int, int], np.dtype[np.uint8]],
            tex_idx: int
        ) -> None:
        self.__meshes.append(Mesh(
            vertices,
            uvs,
            triangles,
            tex_idx
        ))

    def add_texture(self, texture: any, tex_idx: int) -> None:
        if self.__textures.get(tex_idx) is None:
            self.__textures[tex_idx] = texture
    
    def get_texture(self, id: int) -> any:
        return self.__textures[id]
    
    def IterateMeshes(self) -> Generator[Mesh, None, None]:
        for mesh in self.__meshes:
            yield mesh