defmodule AFK.State.Keymap do
  @moduledoc false

  alias AFK.Keycode.{Layer, None, Transparent}

  @enforce_keys [:layers, :counter]
  defstruct [:layers, :counter]

  @type t :: %__MODULE__{
          layers: %{
            optional(non_neg_integer) => %{
              active: bool,
              activations: %{optional(atom) => AFK.Keycode.t(), optional(:default) => true},
              layer: AFK.Keymap.layer()
            }
          },
          counter: [non_neg_integer]
        }

  @spec new(AFK.Keymap.t()) :: t
  def new([]) do
    struct!(__MODULE__, layers: %{}, counter: [])
  end

  def new(keymap) when is_list(keymap) do
    layers =
      keymap
      |> Enum.with_index()
      |> Map.new(fn {layer, index} ->
        {index,
         %{
           active: false,
           activations: %{},
           layer: layer
         }}
      end)
      |> put_in([0, :active], true)
      |> put_in([0, :activations, :default], true)

    counter = Enum.to_list((Enum.count(layers) - 1)..0)
    struct!(__MODULE__, layers: layers, counter: counter)
  end

  @spec find_keycode(t, atom) :: AFK.Keycode.t()
  def find_keycode(%__MODULE__{} = keymap, key) do
    case do_find_keycode(keymap.layers, keymap.counter, key) do
      %_mod{} = keycode -> keycode
      %{} -> %None{}
    end
  end

  defp do_find_keycode(layers, counter, key) do
    Enum.reduce_while(counter, layers, fn layer_id, acc ->
      case Map.fetch!(layers, layer_id) do
        %{active: true, layer: %{^key => %Transparent{}}} -> {:cont, acc}
        %{active: true, layer: %{^key => keycode}} -> {:halt, keycode}
        _else -> {:cont, acc}
      end
    end)
  end

  @spec add_activation(t, AFK.Keycode.Layer.t(), atom) :: t
  def add_activation(%__MODULE__{} = keymap, %Layer{} = keycode, key) do
    layers =
      keymap.layers
      |> put_in([keycode.layer, :activations, key], keycode)
      |> Map.update!(keycode.layer, fn layer ->
        if map_size(layer.activations) > 0 do
          Map.put(layer, :active, true)
        end
      end)

    %{keymap | layers: layers}
  end

  @spec remove_activation(t, AFK.Keycode.Layer.t(), atom) :: t
  def remove_activation(%__MODULE__{} = keymap, %Layer{} = keycode, key) do
    layers =
      keymap.layers
      |> update_in([keycode.layer, :activations], &Map.delete(&1, key))
      |> Map.update!(keycode.layer, fn layer ->
        if map_size(layer.activations) == 0 do
          Map.put(layer, :active, false)
        else
          layer
        end
      end)

    %{keymap | layers: layers}
  end

  @spec toggle_activation(t, AFK.Keycode.Layer.t(), atom) :: t
  def toggle_activation(%__MODULE__{} = keymap, %Layer{} = keycode, key) do
    case keymap.layers[keycode.layer].activations[key] do
      ^keycode -> remove_activation(keymap, keycode, key)
      nil -> add_activation(keymap, keycode, key)
    end
  end

  @spec set_default(t, AFK.Keycode.Layer.t(), atom) :: t
  def set_default(%__MODULE__{} = keymap, %Layer{} = keycode, _key) do
    layers =
      keymap.layers
      |> Map.new(fn {layer_id, layer} ->
        cond do
          layer.activations[:default] ->
            {layer_id, layer |> update_in([:activations], &Map.delete(&1, :default)) |> Map.put(:active, false)}

          layer_id == keycode.layer ->
            {layer_id, layer |> put_in([:activations, :default], true) |> Map.put(:active, true)}

          true ->
            {layer_id, layer}
        end
      end)

    %{keymap | layers: layers}
  end
end
