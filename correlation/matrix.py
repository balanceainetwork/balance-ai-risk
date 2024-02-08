import pandas as pd


class CorrelationMatrix:
    _MIN_CORRELATION = 0.65

    def __init__(self):
        self.matrix = pd.read_json('{}')

    def set(self, matrix_json):
        self.matrix = pd.DataFrame(matrix_json)

    def check_corr(self, asset1, asset2):
        if asset1 == asset2:
            return 0

        if asset1 in self.matrix.columns and asset2 in self.matrix.index and \
                self.matrix.at[asset1, asset2] > CorrelationMatrix._MIN_CORRELATION:
            return 1

        if asset1 in self.matrix.columns and asset2 in self.matrix.index \
                and self.matrix.at[asset1, asset2] < -CorrelationMatrix._MIN_CORRELATION:
            return -1

        return 0

    def check_pos_corr(self, asset1, asset2):
        if self.check_corr(asset1, asset2) == 1:
            return True

        return False

    def check_neg_corr(self, asset1, asset2):
        if self.check_corr(asset1, asset2) == -1:
            return True

        return False



