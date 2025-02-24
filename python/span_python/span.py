from model import Model
from typing import Generator


class Span:
    __tex_id: int

    __uv_1: tuple[float, float]
    __uv_2: tuple[float, float]

    __span_length: int

    def __init__(self) -> None:
        self.__tex_id = 0
        self.__uv_1 = (0.0, 0.0)
        self.__uv_2 = (0.0, 0.0)
        self.__span_length = 0

    def set_span(
            self,
            u_1: float, v_1: float,
            u_2: float, v_2: float,
            x_1: int, x_2: int
        ) -> None:
        self.__uv_1[0] = u_1
        self.__uv_1[1] = v_1
        self.__uv_2[0] = u_2
        self.__uv_2[1] = v_2
        self.__span_length = x_2 - x_1 + 1

    def set_texture(self, tex_id: int) -> None:
        self.__tex_id = tex_id

    def make_tex_stream(self, model: Model) -> Generator[tuple[int, int, int], None, None]:
        texture = model.get_texture(self.__tex_id)
        
        counter: int = 0
        while counter < self.__span_length:
            yield (0, 255, 0)
            counter += 1