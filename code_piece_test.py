#!/usr/bin/env python3


def make_edge_index_test():
  edge_indexes = []
  src_annotation = [[0, 1], [0, 2], [0, 3], [1, 4], [1, 5]]
  cluster_id2token_pos = {}
  for cluster_id, token_pos in src_annotation:
    if cluster_id not in cluster_id2token_pos:
      cluster_id2token_pos[cluster_id] = []
    cluster_id2token_pos[cluster_id].append(token_pos)
  edge_index = [[], []]  # COO format
  for cluster_id, token_pos_list in cluster_id2token_pos.items():
    for i in token_pos_list:
      for j in token_pos_list:
        if i != j:
          edge_index[0].append(i)
          edge_index[1].append(j)
  edge_indexes.append(edge_index)
  print(src_annotation)
  print(edge_indexes)


if __name__ == "__main__":
  make_edge_index_test()
