from src import twitter
from src.tools import file_tools as ft

if __name__ == '__main__':
    ids_path = ft.join_path(ft.basic_path, 'ids.txt')
    twitter.load_by_ids(path=ids_path)