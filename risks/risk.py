from dataclasses import dataclass
from typing import List


@dataclass
class Risk:
    name: str
    params: List[str]
    params2: List[str]

    def get_param(self, index:'int')->str:
        return self.params[index]

    def get_param2(self, string:'str')->str:
        return self.params2[string]

    def get_params(self):
        if self.params is None:
            return 0
        else:
            return len(self.params)
