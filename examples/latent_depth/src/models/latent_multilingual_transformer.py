from fairseq.models import (
    register_model,
    register_model_architecture,
)
from fairseq.models.transformer import (
    base_architecture,
    TransformerEncoder,
    TransformerDecoder,
)
from fairseq.models.multilingual_transformer import MultilingualTransformerModel, base_multilingual_architecture

from .latent_transformer import (
    LatentTransformerEncoder,
    LatentTransformerDecoder,
)

@register_model('latent_multilingual_transformer')
class LatentMultilingualTransformerModel(MultilingualTransformerModel):
    """Train Transformer models for multiple language pairs simultaneously.
    TODO
    """
    @classmethod
    def _get_module_class(cls, is_encoder, args, lang_dict, embed_tokens, langs):
        if is_encoder:
            if hasattr(args, "encoder_latent_layer") and args.encoder_latent_layer:
                return LatentTransformerEncoder(args, lang_dict, embed_tokens, num_logits=len(langs))
            else:
                return TransformerEncoder(args, lang_dict, embed_tokens)
        else:
            if hasattr(args, "decoder_latent_layer") and args.decoder_latent_layer:
                return LatentTransformerDecoder(
                    args, lang_dict, embed_tokens, num_logits=len(langs)
                )
            else:
                return TransformerDecoder(args, lang_dict, embed_tokens)

@register_model_architecture('latent_multilingual_transformer', 'latent_multilingual_transformer')
def latent_multilingual_architecture(args):
    args.encoder_embed_dim = getattr(args, 'encoder_embed_dim', 512)
    args.encoder_ffn_embed_dim = getattr(args, 'encoder_ffn_embed_dim', 1024)
    args.encoder_attention_heads = getattr(args, 'encoder_attention_heads', 4)
    args.encoder_layers = getattr(args, 'encoder_layers', 12)
    args.decoder_embed_dim = getattr(args, 'decoder_embed_dim', 512)
    args.decoder_ffn_embed_dim = getattr(args, 'decoder_ffn_embed_dim', 1024)
    args.decoder_attention_heads = getattr(args, 'decoder_attention_heads', 4)
    args.decoder_layers = getattr(args, 'decoder_layers', 24)
    args.share_encoders = getattr(args, 'share_encoders', True)
    args.share_decoders = getattr(args, 'share_decoders', True)
    args.share_encoder_embeddings = getattr(args, 'share_encoder_embeddings', True)
    args.share_decoder_embeddings = getattr(args, 'share_decoder_embeddings', True)

    base_architecture(args)