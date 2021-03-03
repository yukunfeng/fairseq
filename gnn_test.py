import torch
import torch_geometric
from torch_geometric.nn.conv.gat_conv import GATConv

torch.manual_seed(0)


def gat_test_single():
  # example sentence: w0 w1 w2 w3 w4
  # suppose, w0 and w1 is connected, w2 and w3 is connected
  # how about the edge index
  # [[0, 1, 2, 3], [1, 0, 3, 2]]
  edge_index = torch.tensor([[0, 1, 2, 3], [1, 0, 3, 2]], dtype=torch.long)
  x = torch.rand((5, 3))
  gnn = GATConv(x.shape[1], x.shape[1])
  gnn_out = gnn(x, edge_index)


def gat_test_minibatch():
  # example sentence: w0 w1 w2 w3 w4
  # suppose, w0 and w1 is connected, w2 and w3 is connected
  # how about the edge index
  # [[0, 1, 2, 3], [1, 0, 3, 2]]
  node_dim = 3
  data_list = []
  gnn = GATConv(node_dim, node_dim)
  for i in range(3):
    edge_index = torch.tensor([[0, 1, 2, 3], [1, 0, 3, 2]], dtype=torch.long)
    x = torch.rand((5, node_dim))
    data_list.append(torch_geometric.data.Data(x=x, edge_index=edge_index))

    gnn_out = gnn(x, edge_index)
    print(f"i: {i}")
    print(gnn_out)

  batch = torch_geometric.data.Batch.from_data_list(data_list)
  gnn_out = gnn(x=batch.x, edge_index=batch.edge_index)
  print(f"using batch")
  print(gnn_out)


if __name__ == "__main__":
  #  gat_test()
  gat_test_minibatch()
