module WordsHelper
  def frame_spanner(frame)
    frame.gsub('PP', '<span title="prepositional phrase">PP</span>')
  end

  def model_count(model)
    count = eval(model.capitalize).count.to_s

    # there must be a more standard method, but for now I'm kluging this
    md = /^(\d+)(\d{3})$/.match count
    md ? md[1] + ',' + md[2] : count
  end
end
