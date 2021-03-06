
React = require('react')
ReactDOM = require('react-dom')

{
  Entity,
  RichUtils
  AtomicBlockUtils
  EditorBlock
} = require('draft-js')

axios = require("axios")

{ updateDataOfBlock } = require('../../model/index.js')

class EmbedBlock extends React.Component
  constructor: (props) ->
    super props
    #api_key = "86c28a410a104c8bb58848733c82f840"

    @state = 
      embed_data: @defaultData()
      error: ""

  defaultData: ->
    existing_data = @.props.block.getData().toJS()
    existing_data.embed_data || {}

  # will update block state
  updateData: =>
    blockProps = @.props.blockProps
    block = @.props.block
    getEditorState = @props.blockProps.getEditorState
    setEditorState = @props.blockProps.setEditorState
    data = block.getData();
    newData = data.merge(@state)
    setEditorState(updateDataOfBlock(getEditorState(), block, newData))

  dataForUpdate: =>

    @.props.blockProps.data.toJS()

  componentDidMount: =>
    
    return unless @.props.blockProps.data
    
    # ensure data isnt already loaded
    # unless @dataForUpdate().endpoint or @dataForUpdate().provisory_text
      
    unless @dataForUpdate().endpoint or @dataForUpdate().provisory_text
      #debugger
      return

    axios
      method: 'get'
      url: "#{@dataForUpdate().endpoint}#{@dataForUpdate().provisory_text}&scheme=https"
    .then (result)=> 
      
      @setState
        embed_data: result.data #JSON.parse(data.responseText)
      , @updateData    
    .catch (error)=>
      
      @setState
        error: error.response.data.error_message
      console.log("TODO: error")
      
  classForImage: ->
    if @state.embed_data.images then "" else "mixtapeImage--empty u-ignoreBlock"
    #if @state.embed_data.thumbnail_url then "" else "mixtapeImage--empty u-ignoreBlock"

  picture: ->
    if @state.embed_data.images and @state.embed_data.images.length > 0 then @state.embed_data.images[0].url else ""

  render: ->
    #block = @.props;
    #foo = @.props.blockProps;
    #data = Entity.get(block.block.getEntityAt(0)).getData();
    console.log "ERROR", @state.error
    return(
      <span>
        {
          if @picture()
            <a target='_blank'
              className="js-mixtapeImage mixtapeImage #{@classForImage()}"
              href={@state.embed_data.url} 
              style={{backgroundImage: "url('#{@picture()}')"}}>
            </a>
        }

        {
          if @state.error
            <h2>{@state.error}</h2>
        }
        
        <a className='markup--anchor markup--mixtapeEmbed-anchor' 
          target='_blank' href={@state.embed_data.url}>
          <strong className='markup--strong markup--mixtapeEmbed-strong'>
            {@state.embed_data.title}
          </strong>
          <em className='markup--em markup--mixtapeEmbed-em'>
            {@state.embed_data.description}
          </em>
        </a>
        {@state.embed_data.provider_url}
      </span>
    )

module.exports = EmbedBlock