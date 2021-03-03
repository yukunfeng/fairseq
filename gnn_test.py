import torch
from torch_geometric.nn.conv.gat_conv import GATConv

def gat_test_single():
  # example sentence: w0 w1 w2 w3 w4
  # suppose, w0 and w1 is connected, w2 and w3 is connected
  # how about the edge index
  # [[0, 1, 2, 3], [1, 0, 3, 2]]
  edge_index = torch.tensor([[0, 1, 2, 3], [1, 0, 3, 2]], dtype=torch.long)
  x = torch.rand((5, 3))
  gnn = GATConv(x.shape[1], x.shape[1])
  gnn_out = gnn(x, edge_index)

if __name__ == "__main__":
  gat_test()
